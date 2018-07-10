class Decision
	
	class Record
		@attributes = Array.new
		@className = nil
		
		def initialize(atts, clname)
			@attributes = atts
			@className = clname
		end
		
		def className
			@className
		end
		
		def atts
			@attributes
		end
	end
	
	class Node
		@nodeType = nil
		@condition = nil
		@className = nil
		@left = nil
		@right = nil
		
		def initialize(nodeT, val, left, right)
			@nodeType = nodeT
			@left = left
			@right = right
			
			if(nodeT == "internal")
				@condition = val
				@className = -1
			else
				@className = val
				@condition = -1
			end
		end
		
		def clname
			@className
		end
		
		def left
			@left
		end
		
		def right
			@right
		end
		
		def type
			@nodeType
		end
		
		def condition
			@condition
		end
	end
	
	def inspect
		@root
		@records
		@attributes
		@numberRecords
		@numberAttributes
		@numberClasses
		
		self
	end
	
	def initialize
		@root = nil
		@records = Array.new
		@attributes = Array.new
		@numberRecords = 0
		@numberAttributes = 0
		@numberClasses = 0
		
		loadTrainingData("./dtrain.txt")
		
		buildTree()
		
		cl = [0,1,0,0,1]
		classify(cl)
		cl = [1,1,1,0,1]
		classify(cl)
		cl = [1,0,0,0,1]
		classify(cl)
		cl = [1,0,0,1,0]
		classify(cl)
		cl = [1,1,1,1,1]
		classify(cl)
	end
	
	
	def buildTree
		@root = build(@records, @attributes)
	end
	
	def build(records, attributes)
		ret = nil
		
		if(sameClass(records))
			classname = records[0].className
			
			ret = Node.new("leaf", classname, nil, nil)
		elsif attributes.empty?
			classname = majorityClass(records)
			
			ret = Node.new("leaf", classname, nil, nil)
		else
			condition = bestCondition(records, attributes)
			
			leftRecords = collect(records, condition, 0)
			rightRecords = collect(records, condition, 1)
			
			if(leftRecords.empty? || rightRecords.empty?)
				className = majorityClass(records)
				ret = Node.new("leaf", className, nil, nil)
			else
				leftAttributes = copyAttributes(attributes)
				rightAttributes = copyAttributes(attributes)
				
				rightAttributes = rem(rightAttributes, condition)
				leftAttributes = rem(leftAttributes, condition)
				
				left = build(leftRecords, leftAttributes)
				right = build(rightRecords, rightAttributes)
				
				ret = Node.new("internal", condition, left, right)
			end
		end
		
		ret
	end
	
	def classify atts
		puts atts.to_s
		
		current = @root
		
		while current.type == "internal"
			if(atts[current.condition-1] == 0)
				current = current.left
			else
				current = current.right
			end
		end
		
		puts current.clname
	end
	
	def rem(atts, condition)
		result = Array.new
		size = atts.length
		
		size.times{|s|
			if(atts[s] != condition)
				result.push(atts[s])
			end
		}
		
		result
	end
	
	def copyAttributes(attributes)
		result = Array.new
		size = attributes.length
		
		size.times{|i|
			temp = attributes[i]
			result.push(temp)
		}
		
		result
	end
	
	def bestCondition(records, attributes)
		minValue = evaluate(records, attributes[0])
		
		minIndex = 0
		size = records.length
		size.times{|i|
			value = evaluate(records, attributes[i])
			
			if(value < minValue)
				minValue = value
				minIndex = i
			end
		}
		
		ret = attributes[minIndex]
		
		ret
	end
	
	def evaluate(records, attribute)
		leftRecords = collect(records, attribute, 0)
		rightRecords = collect(records, attribute, 1)
		
		entropyLeft = entropy(leftRecords)
		entropyRight = entropy(rightRecords)
		
		leftSize = leftRecords.length
		rightSize = rightRecords.length
		size = records.length
		
		left = entropyLeft*leftSize/size
		right = entropyRight*rightSize/size
		
		average = left + right
		
		average
	end
	
	def entropy(records)
		frequency = Array.new
		
		@numberClasses.times{|i|
			frequency[i] = 0.0
		}
		
		size = records.length
		size.times{|i|
			c = records[i].className-1
			frequency[c] += 1
		}
		
		sum = 0.0
		@numberClasses.times{|i|
			sum = sum + frequency[i]
		}
		
		@numberClasses.times{|i|
			frequency[i] = frequency[i]/sum
		}
		
		sum = 0.0
		@numberClasses.times{|i|
			sum = sum + frequency[i]*frequency[i]
		}
		
		
		ret = 1 - sum
		
		ret
	end
	
	def collect(records, condition, value)
		result = Array.new
		size = records.length
		size.times{|x|
			##### This had to be added in case condition is nil
			##### Might have to check this lataer
			if(condition)
				if(records[x].atts[condition - 1] == value)
					result.push(records[x])
				end
			end
		}
		
		result
	end
	
	def majorityClass(records)
		frequency = Array.new
		
		@numberClasses.times{|x|
			frequency[x] = 0
		}
		
		size = records.length
		size.times{|i|
			frequency[records[i].className -1] +=1
		}
		
		maxIndex = 0
		@numberClasses.times{|i|
			if(frequency[i] > frequency[maxIndex])
				maxIndex = i
			end
		}
		
		ret = maxIndex + 1
		
		ret
	end
	
	def sameClass(records)
		size = records.length
		
		size.times{|x|
			if(records[x].className != records[0].className)
				return false
			end
		}
		return true
	end
	
	def debug
		@attributes.each{|x|
			puts x
		}
	end
	
	def loadTrainingData trainingFile
		allLines = Array.new
		
		lines = File.open(trainingFile).to_a
		fstLine = lines.first
		fstLine = fstLine.lstrip
		fstLine = fstLine.rstrip
		
		data = fstLine.split
		@numberRecords = data[0].to_i
		@numberAttributes = data[1].to_i
		@numberClasses = data[2].to_i
		
		File.readlines(trainingFile).each do |line|
			line = line.lstrip
			line = line.rstrip
			if(line != fstLine && line.length > 0 && line != nil && line != "")
				allLines.push(line)
			end
		end
		
		allLines.each{ |ln|
			attributeArray = Array.new
			claname = nil
			
			comps = ln.split
			
			num = 0
			comps.each{ |p|
				if(num < 5)
					ret = convertAttribute(p, num+1)
					attributeArray.push(ret)
					num +=1
				else
					label = p
					claname = convertString(p)
					num = 0
				end
			}
			
			rec = Record.new(attributeArray, claname)
			
			@records.push(rec)
		}
		
		@numberAttributes.times{ |p|
			q = p + 1
			@attributes.push(q)
		}
	end
	
	def convertString(label)
		value = nil
		
		if(label == "highrisk")
			value = 1
		elsif(label == "mediumrisk")
			value = 2
		elsif(label == "lowrisk")
			value = 3
		else
			value = 4
		end
		
		value
	end
	
	def convertAttribute(label, index)
		value = nil
		
		if(index == 1)
			if(label == "highschool")
				value = 0
			elsif(label == "college")
				value = 1
			end
		elsif(index == 2)
			if(label == "smoker")
				value = 0			
			elsif(label == "nonsmoker")
				value = 1
			end
		elsif(index == 3)
			if(label == "married")
				value = 0			
			elsif(label == "notmarried")
				value = 1			
			end
		elsif(index == 4)
			if(label == "male")
				value = 0			
			elsif(label == "female")
				value = 1			
			end
		elsif(index == 5)
			if(label == "works")
				value = 0			
			elsif(label == "retired")
				value = 1			
			end
		end
		
		value
	end
end